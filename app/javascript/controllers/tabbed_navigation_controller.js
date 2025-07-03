import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabsContainer"]
  
  connect() {
    console.log("TabbedNavigationController connected");
    this.tabs = [];
    this.pinnedPetIds = new Set();
    this.setupEventListeners();
    
    // Initialize with server-rendered pinned tabs
    this.initializeFromServerRenderedTabs();
    
    // Restore unpinned tab if needed
    this.restoreUnpinnedTab();
  }
  
  disconnect() {
    this.removeEventListeners();
  }
  
  setupEventListeners() {
    this.handlePetOpened = this.handlePetOpened.bind(this);
    this.handlePetUnpinned = this.handlePetUnpinned.bind(this);
    window.addEventListener('pet:opened', this.handlePetOpened);
    window.addEventListener('pet:unpinned', this.handlePetUnpinned);
  }
  
  removeEventListeners() {
    window.removeEventListener('pet:opened', this.handlePetOpened);
    window.removeEventListener('pet:unpinned', this.handlePetUnpinned);
  }
  
  initializeFromServerRenderedTabs() {
    // Get all existing tabs from the DOM (server-rendered pinned tabs)
    const existingTabs = this.tabsContainerTarget.querySelectorAll('.nav-tab');
    
    existingTabs.forEach(tabElement => {
      const tabData = {
        id: tabElement.dataset.tabId || null,
        tabable_id: tabElement.dataset.petId || null,
        title: tabElement.querySelector('.nav-tab-title').textContent,
        url: tabElement.dataset.tabUrl,
        tab_type: tabElement.dataset.tabType
      };
      
      this.tabs.push(tabData);
      
      // Add to pinnedPetIds if it's a pet tab
      if (tabData.tab_type === 'pet' && tabData.tabable_id) {
        this.pinnedPetIds.add(String(tabData.tabable_id));
      }
    });
    
    console.log(`Initialized with ${this.tabs.length} server-rendered pinned tabs`);
  }
  
  restoreUnpinnedTab() {
    const petContainer = document.querySelector('[data-controller~="pet"]');
    const unpinnedTab = sessionStorage.getItem('currentUnpinnedPetTab');
    
    if (petContainer && unpinnedTab) {
      try {
        const { petId, petName, petUrl } = JSON.parse(unpinnedTab);
        console.log(`Restoring unpinned tab for pet: ${petName} (ID: ${petId})`);
        
        // Check if this pet is already pinned
        if (this.pinnedPetIds.has(String(petId))) {
          console.log(`Pet ${petId} is already pinned, not restoring as unpinned tab`);
          return;
        }
        
        // Check if tab already exists
        let existingTab = this.tabsContainerTarget.querySelector(`[data-pet-id="${petId}"]`);
        if (existingTab) {
          console.log(`Tab for pet ${petId} already exists, making it active`);
          this.makeTabActive(existingTab);
          return;
        }
        
        // Add the unpinned tab
        const tabData = {
          id: null,
          tabable_id: petId,
          title: petName,
          url: petUrl,
          tab_type: 'pet'
        };
        this.tabs.push(tabData);
        const tabElement = this.createTabElement(tabData);
        this.tabsContainerTarget.appendChild(tabElement);
        this.makeTabActive(tabElement);
        console.log(`Successfully restored unpinned tab for pet: ${petName}`);
      } catch (error) {
        console.error('Error restoring unpinned tab:', error);
        sessionStorage.removeItem('currentUnpinnedPetTab');
      }
    }
  }
  
  renderTabs() {
    // Only render tabs that aren't already in the DOM (unpinned tabs)
    const existingTabIds = new Set();
    this.tabsContainerTarget.querySelectorAll('.nav-tab').forEach(tab => {
      const tabId = tab.dataset.tabId || tab.dataset.petId;
      if (tabId) existingTabIds.add(tabId);
    });
    
    this.tabs.forEach(tab => {
      const tabId = tab.id || tab.tabable_id;
      if (!existingTabIds.has(String(tabId))) {
        this.tabsContainerTarget.appendChild(this.createTabElement(tab));
      }
    });
  }
  
  createTabElement(tab) {
    const tabDiv = document.createElement('div');
    tabDiv.className = 'nav-tab';
    tabDiv.dataset.tabId = tab.id || '';
    tabDiv.dataset.tabType = tab.tab_type;
    tabDiv.dataset.tabUrl = tab.url;
    tabDiv.dataset.petId = tab.tabable_id || '';
    let isActive = false;
    try {
      isActive = window.location.pathname === new URL(tab.url, window.location.origin).pathname;
    } catch (e) {
      isActive = window.location.pathname === tab.url;
    }
    const isPinned = this.pinnedPetIds.has(String(tab.tabable_id));
    tabDiv.innerHTML = `
      <div class="nav-tab-content ${isActive ? 'active' : ''}" data-action="click->tabbed-navigation#switchToTab">
        <span class="nav-tab-title">${tab.title}</span>
        <div class="nav-tab-actions">
          ${isPinned
            ? `<button class="nav-tab-close" data-action="click->tabbed-navigation#unpinAndClose" title="Unpin and close tab"><i class="fas fa-times"></i></button>`
            : `<button class="nav-tab-pin" data-action="click->tabbed-navigation#pinTab" title="Pin tab"><i class="fas fa-thumbtack"></i></button>`
          }
        </div>
      </div>
    `;
    return tabDiv;
  }
  
  switchToTab(event) {
    const tabElement = event.currentTarget.closest('.nav-tab');
    const url = tabElement.dataset.tabUrl;
    const petId = tabElement.dataset.petId;
    
    // Check if this is a pinned tab
    const isPinned = this.pinnedPetIds.has(String(petId));
    
    if (isPinned) {
      console.log(`Switching to pinned tab for pet: ${petId}, removing unpinned tabs`);
      
      // Remove all unpinned tabs from the DOM and tabs array
      const unpinnedTabs = this.tabsContainerTarget.querySelectorAll('.nav-tab');
      unpinnedTabs.forEach(tab => {
        const tabPetId = tab.dataset.petId;
        if (tabPetId && !this.pinnedPetIds.has(String(tabPetId))) {
          console.log(`Removing unpinned tab for pet: ${tabPetId}`);
          tab.remove();
          // Remove from tabs array
          this.tabs = this.tabs.filter(t => String(t.tabable_id) !== String(tabPetId));
        }
      });
      
      // Clear sessionStorage for unpinned tabs
      sessionStorage.removeItem('currentUnpinnedPetTab');
      console.log('Cleared sessionStorage for unpinned tabs');
    }
    
    if (url) {
      window.location.href = url;
    }
  }
  
  async pinTab(event) {
    event.stopPropagation();
    const tabElement = event.currentTarget.closest('.nav-tab');
    const petId = tabElement.dataset.petId;
    if (!petId) return;
    
    console.log(`Pinning tab for pet: ${petId}`);
    
    await fetch('/pinned_tabs', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify({ pet_id: petId })
    });
    
    this.pinnedPetIds.add(petId);
    
    // Remove from sessionStorage if present
    const unpinnedTab = sessionStorage.getItem('currentUnpinnedPetTab');
    if (unpinnedTab) {
      const { petId: storedId } = JSON.parse(unpinnedTab);
      if (String(storedId) === String(petId)) {
        sessionStorage.removeItem('currentUnpinnedPetTab');
        console.log(`Removed pet ${petId} from sessionStorage after pinning`);
      }
    }
    
    // Re-render the tab as pinned (with X icon)
    const tabData = this.tabs.find(t => String(t.tabable_id) === String(petId));
    if (tabData) {
      const newTab = this.createTabElement(tabData);
      tabElement.replaceWith(newTab);
      this.makeTabActive(newTab);
      console.log(`Tab for pet ${petId} is now pinned`);
    }
  }
  
  async unpinAndClose(event) {
    event.stopPropagation();
    const tabElement = event.currentTarget.closest('.nav-tab');
    const petId = tabElement.dataset.petId;
    const tabId = tabElement.dataset.tabId;
    
    console.log(`Unpinning and closing tab for pet: ${petId}`);
    
    // Check if we're currently on this pet's page
    const petContainer = document.querySelector('[data-controller~="pet"]');
    const currentPetId = petContainer ? petContainer.dataset.petId : null;
    const isOnCurrentPetPage = currentPetId && String(currentPetId) === String(petId);
    
    if (petId) {
      await fetch(`/pinned_tabs/unpin_pet?pet_id=${petId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'X-Requested-With': 'XMLHttpRequest'
        }
      });
      this.pinnedPetIds.delete(petId);
      
      // Remove from sessionStorage if present
      const unpinnedTab = sessionStorage.getItem('currentUnpinnedPetTab');
      if (unpinnedTab) {
        const { petId: storedId } = JSON.parse(unpinnedTab);
        if (String(storedId) === String(petId)) {
          sessionStorage.removeItem('currentUnpinnedPetTab');
          console.log(`Removed pet ${petId} from sessionStorage after unpinning`);
        }
      }
    }
    
    if (isOnCurrentPetPage) {
      // If we're on the current pet's page, just unpin it and keep the tab
      console.log(`On current pet page, keeping tab for pet ${petId} but unpinning it`);
      
      // Update the tab to show as unpinned (with pin icon)
      const tabData = this.tabs.find(t => String(t.tabable_id) === String(petId));
      if (tabData) {
        const newTab = this.createTabElement(tabData);
        tabElement.replaceWith(newTab);
        this.makeTabActive(newTab);
        console.log(`Tab for pet ${petId} is now unpinned but still visible`);
      }
    } else {
      // If we're not on the pet's page, remove the tab completely
      console.log(`Not on current pet page, removing tab for pet ${petId}`);
      tabElement.remove();
      // Remove from tabs array
      this.tabs = this.tabs.filter(t => String(t.tabable_id) !== String(petId));
      console.log(`Tab for pet ${petId} has been removed`);
    }
    
    // Notify pets index to update pin button
    window.dispatchEvent(new CustomEvent('pet:unpinned_ui', { detail: { petId } }));
    console.log('[DEBUG] pet:unpinned_ui event dispatched for petId', petId);
  }
  
  closeAllTabs() {
    console.log('Closing all tabs');
    const tabs = this.tabsContainerTarget.querySelectorAll('.nav-tab');
    tabs.forEach(tab => {
      const closeButton = tab.querySelector('.nav-tab-close');
      if (closeButton) closeButton.click();
    });
  }
  
  handlePetOpened(event) {
    const { petId, petName, petUrl, fromPinButton } = event.detail;
    // Guard: Only create a new tab if one does not already exist
    let existingTab = this.tabsContainerTarget.querySelector(`[data-pet-id="${petId}"]`);
    if (existingTab) {
      console.log(`Tab for pet ${petId} already exists, making it active`);
      this.makeTabActive(existingTab);
      return;
    }

    // Check if this pet is already pinned
    if (this.pinnedPetIds.has(String(petId))) {
      console.log(`Pet ${petId} is already pinned, not creating duplicate tab`);
      return;
    }

    if (fromPinButton) {
      // Create pinned tab
      console.log(`Creating pinned tab for pet: ${petName} (ID: ${petId})`);

      // Add new tab as pinned
      const tabData = {
        id: null,
        tabable_id: petId,
        title: petName,
        url: petUrl,
        tab_type: 'pet'
      };
      this.tabs.push(tabData);
      
      // Add to pinnedPetIds immediately
      this.pinnedPetIds.add(String(petId));
      
      const tabElement = this.createTabElement(tabData);
      this.tabsContainerTarget.appendChild(tabElement);
      this.makeTabActive(tabElement);
      console.log(`Created pinned tab for pet: ${petName} (ID: ${petId})`);

      // Save to database
      this.savePinnedTabToDatabase(petId);
    } else {
      // Create unpinned tab
      console.log(`Creating unpinned tab for pet: ${petName} (ID: ${petId})`);

      // Add new tab as unpinned
      const tabData = {
        id: null,
        tabable_id: petId,
        title: petName,
        url: petUrl,
        tab_type: 'pet'
      };
      this.tabs.push(tabData);
      
      const tabElement = this.createTabElement(tabData);
      this.tabsContainerTarget.appendChild(tabElement);
      this.makeTabActive(tabElement);
      console.log(`Created unpinned tab for pet: ${petName} (ID: ${petId})`);

      // Store in sessionStorage for unpinned tabs
      sessionStorage.setItem('currentUnpinnedPetTab', JSON.stringify({
        petId: petId,
        petName: petName,
        petUrl: petUrl
      }));
    }
  }

  async savePinnedTabToDatabase(petId) {
    try {
      await fetch('/pinned_tabs', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({ pet_id: petId })
      });
      console.log(`Saved pinned tab for pet ${petId} to database`);
      
      // Notify pets index to update pin button
      window.dispatchEvent(new CustomEvent('pet:pinned', { detail: { petId } }));
    } catch (error) {
      console.error(`Failed to save pinned tab for pet ${petId}:`, error);
      // Remove from pinnedPetIds if save failed
      this.pinnedPetIds.delete(String(petId));
    }
  }

  handlePetUnpinned(event) {
    const { petId } = event.detail;
    this.pinnedPetIds.delete(String(petId));
    // Remove the tab if present
    let tab = this.tabsContainerTarget.querySelector(`[data-pet-id="${petId}"]`);
    if (tab) tab.remove();
    this.tabs = this.tabs.filter(t => String(t.tabable_id) !== String(petId));
    // Notify pets index to update pin button
    window.dispatchEvent(new CustomEvent('pet:unpinned_ui', { detail: { petId } }));
    console.log('[DEBUG] pet:unpinned_ui event dispatched for petId', petId);
  }

  makeTabActive(tabElement) {
    this.tabsContainerTarget.querySelectorAll('.nav-tab-content').forEach(tab => {
      tab.classList.remove('active');
    });
    const tabContent = tabElement.querySelector('.nav-tab-content');
    if (tabContent) {
      tabContent.classList.add('active');
    }
  }
  
  async unpinAllTabs(event) {
    event.preventDefault();
    // Unpin all pinned tabs for the user
    const petIds = Array.from(this.pinnedPetIds);
    for (const petId of petIds) {
      await fetch(`/pinned_tabs/unpin_pet?pet_id=${petId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'X-Requested-With': 'XMLHttpRequest'
        }
      });
      this.pinnedPetIds.delete(petId);
      // Remove tab from DOM and tabs array
      const tabElement = this.tabsContainerTarget.querySelector(`[data-pet-id="${petId}"]`);
      if (tabElement) tabElement.remove();
      this.tabs = this.tabs.filter(t => String(t.tabable_id) !== String(petId));
    }
    // Remove any unpinned tab from sessionStorage
    sessionStorage.removeItem('currentUnpinnedPetTab');
  }

  async pinAllTabs(event) {
    event.preventDefault();
    // Pin all currently open tabs (unpinned pet tabs)
    const unpinnedTabs = this.tabs.filter(tab => tab.tab_type === 'pet' && !this.pinnedPetIds.has(String(tab.tabable_id)));
    for (const tab of unpinnedTabs) {
      await fetch('/pinned_tabs', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({ pet_id: tab.tabable_id })
      });
      this.pinnedPetIds.add(String(tab.tabable_id));
      // Update the tab in the DOM to show as pinned
      const tabElement = this.tabsContainerTarget.querySelector(`[data-pet-id="${tab.tabable_id}"]`);
      if (tabElement) {
        const newTab = this.createTabElement(tab);
        tabElement.replaceWith(newTab);
        this.makeTabActive(newTab);
      }
    }
    // Remove any unpinned tab from sessionStorage
    sessionStorage.removeItem('currentUnpinnedPetTab');
  }
} 